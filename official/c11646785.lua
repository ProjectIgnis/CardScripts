--超量機獣エアロボロス
--Super Quantal Mech Beast Aeroboros
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	--Cannot attack unless it has Xyz Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()==0 end)
	c:RegisterEffect(e1)
	--Change 1 monster to face-down Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(aux.NOT(s.quickeffcond))
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--This is a Quick effect if this card has "Super Quantum Green Layer" as Xyz Material
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(s.quickeffcond)
	c:RegisterEffect(e3)
	--Attach 1 "Super Quantum" monster from your hand or field to this card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.attachtg)
	e4:SetOperation(s.attachop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_SUPER_QUANTUM}
s.listed_names={85374678} --"Super Quantum Green Layer"
function s.quickeffcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,85374678)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
function s.attachfilter(c,e,tp,xc)
	return c:IsSetCard(SET_SUPER_QUANTUM) and c:IsMonster() and not c:IsType(TYPE_TOKEN)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp,c) end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,e,tp,c):GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end