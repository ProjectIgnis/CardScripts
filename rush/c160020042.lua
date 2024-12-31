--ギャラクティカ・ロスト・オブリビオン
--Galactica Lost Oblivion
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_GALACTICA_OBLIVION,1,s.ffilter,1)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--destroy monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.accon)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
end
s.named_material={CARD_GALACTICA_OBLIVION}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_GALAXY,fc,sumtype,tp) and c:IsLevel(7,8)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.desfilter(c)
	return c:IsFaceup() and c:GetTextAttack()<=2500 and c:IsNotMaximumModeSide()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	--Effect
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(700)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
	e:SetLabel(1)
end
function s.cfilter(c)
	return (c:GetPreviousPosition()&POS_FACEDOWN)~=0 and (c:GetPosition()&POS_FACEUP)~=0
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Destroy(g2,REASON_EFFECT)
	end
	e:GetLabelObject():SetLabel(0)
end