--メルフィー・マミィ
--Melffy Mommy
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 2 Beast monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),2,2,nil,nil,Xyz.InfiniteMats)
	--Attach 1 Beast monster from your hand or face-up field to this card as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--● 3+: Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>=3 end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--● 4+: You take no damage from battles involving this card
	local e3=e2:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>=4 end)
	c:RegisterEffect(e3)
	--● 5+: When an attack is declared involving this card and an Attack Position monster: You can inflict damage to your opponent equal to that Attack Position monster's ATK
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
function s.attachfilter(c,xyzc,tp)
	return c:IsRace(RACE_BEAST) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,c,tp)
	end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,c,tp):GetFirst()
	if not sc then return end
	if sc:IsLocation(LOCATION_HAND) then Duel.ConfirmCards(1-tp,sc) else Duel.HintSelection(sc) end
	Duel.Overlay(c,sc,true)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc1,bc2=Duel.GetBattleMonster(tp)
	return c:GetOverlayCount()>=5 and bc1 and bc1==c and bc2 and bc2:IsAttackPos() and bc2:HasNonZeroAttack()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local _,bc=Duel.GetBattleMonster(tp)
	e:SetLabelObject(bc)
	bc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToEffect(e) and bc:IsFaceup() and bc:IsAttackPos() then
		Duel.Damage(1-tp,bc:GetAttack(),REASON_EFFECT)
	end
end