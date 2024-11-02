--蛇眼の大炎魔
--Snake-Eyes Diabellstar
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Place battling monsters in the Spell/Trap Zone as Continuous Spells
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.btplcon)
	e1:SetOperation(s.btplop)
	c:RegisterEffect(e1)
	--Place 1 monster from the GY in the Spell/Trap Zone as a Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e2:SetTarget(s.gypltg)
	e2:SetOperation(s.gyplop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.checkzones(c0,c1)
	local p0,p1=c0:GetOwner(),c1:GetOwner()
	if p0==p1 then return Duel.GetLocationCount(p0,LOCATION_SZONE)>1 end
	return Duel.GetLocationCount(p0,LOCATION_SZONE)>0 and Duel.GetLocationCount(p1,LOCATION_SZONE)>0
end
function s.btplcon(e,tp,eg,ep,ev,re,r,rp)
	local bc0,bc1=Duel.GetBattleMonster(tp)
	return bc0 and bc1 and bc0==e:GetHandler() and s.checkzones(bc0,bc1)
end
function s.stplace(c,tp,rc)
	if not Duel.MoveToField(c,tp,c:GetOwner(),LOCATION_SZONE,POS_FACEUP,c:IsMonsterCard()) then return end
	--Treated as a Continuous Spell
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
	c:RegisterEffect(e1)
	return true
end
function s.btplop(e,tp,eg,ep,ev,re,r,rp)
	local bc0,bc1=Duel.GetBattleMonster(tp)
	if bc0 and bc1 and bc0:IsRelateToBattle() and not bc0:IsImmuneToEffect(e) 
		and bc1:IsRelateToBattle() and not bc1:IsImmuneToEffect(e) 
		and s.checkzones(bc0,bc1) and s.stplace(bc0,tp,bc0) then
		s.stplace(bc1,tp,bc0)
	end
end
function s.gyplfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(id) and not c:IsForbidden()
end
function s.gypltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyplfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyplfilter,tp,LOCATION_GRAVE,0,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.gyplfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.gyplop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and s.stplace(tc,tp,c) and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end