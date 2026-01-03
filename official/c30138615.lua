--ナイトメア・アイズ・サクリファイス
--Nightmare-Eyes Restrict
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2 monsters with different Types (Fiend, Illusion, or Spellcaster)
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--Equip 1 monster your opponent controls to this card as an Equip Spell
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_EQUIP)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.eqtg)
	e1a:SetOperation(s.eqop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1b:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetCondition(function(e) return e:GetHandler():GetBattledGroupCount()>0 end)
	c:RegisterEffect(e1b)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e1a)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e1b)
	--Gains ATK equal to the combined ATK of those equipped monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():GetEquipGroup():IsExists(aux.FaceupFilter(Card.HasFlagEffect,id),1,nil) end)
	e2:SetValue(function(e,c) return c:GetEquipGroup():Match(function(c) return c:HasFlagEffect(id) and c:IsFaceup() and c:GetTextAttack()>0 end,nil):GetSum(Card.GetTextAttack) end)
	c:RegisterEffect(e2)
	--If this card battles a monster, neither can be destroyed by that battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(function(e,c) local handler=e:GetHandler() return c==handler or c==handler:GetBattleTarget() end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Your opponent's monsters cannot attack monsters, except this one
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(function(e,c) return c~=e:GetHandler() end)
	c:RegisterEffect(e4)
end
function s.matfilter(c,fc,sumtype,sp,sub,mg,sg)
	return c:IsRace(RACE_FIEND|RACE_ILLUSION|RACE_SPELLCASTER,fc,sumtype,sp) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or not sg:IsExists(Card.IsRace,1,c,c:GetRace(),fc,sumtype,sp))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_MZONE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sc=Duel.SelectMatchingCard(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if sc then
		Duel.HintSelection(sc)
		s.equipop(c,e,tp,sc)
	end
end
function s.eqval(ec,c,tp)
	return ec:IsControler(1-tp)
end
function s.equipop(c,e,tp,tc)
	c:EquipByEffectAndLimitRegister(e,tp,tc,id)
end