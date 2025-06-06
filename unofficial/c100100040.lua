--Ｓｐ－強制転移
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chk==0 then return tc and tc:IsCanRemoveCounter(tp,0x91,3,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	tc:RemoveCounter(tp,0x91,3,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,LOCATION_MZONE,0,1,nil)
		or not Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)
	then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToChangeControler,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)
	local g2=Duel.SelectMatchingCard(1-tp,Card.IsAbleToChangeControler,1-tp,LOCATION_MZONE,0,1,1,nil)
	local c1=g1:GetFirst()
	local c2=g2:GetFirst()
	if Duel.SwapControl(c1,c2,0,0) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_PHASE+PHASE_END)
		c1:RegisterEffect(e1)
		local e2=e1:Clone()
		c2:RegisterEffect(e2)
	end
end