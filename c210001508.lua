--Solar Gun Grenade - Bomb
function c210001508.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCountLimit(1,210001507)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c210001508.cost)
	e1:SetTarget(c210001508.target)
	e1:SetOperation(c210001508.operation)
	c:RegisterEffect(e1)
	--add grenade instead
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,210001508)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c210001508.thidcondition)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c210001508.thidtarget)
	e2:SetOperation(c210001508.thidoperation)
	c:RegisterEffect(e2)
end
c210001508.listed_names={210001508}
function c210001508.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c210001508.filter1(c,tp)
	local cg=c:GetColumnGroup()
	return c:IsSetCard(0x1f69) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(c210001508.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,cg)
end
function c210001508.filter2(c,cg)
	return cg:IsContains(c) and not (c:IsFaceup() and c:IsSetCard(0xf70))
end
function c210001508.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	if chkc then return chkc:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c210001508.filter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c210001508.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	local tc=Duel.SelectTarget(tp,c210001508.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local dg=Duel.GetMatchingGroup(c210001508.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,tc,tc:GetColumnGroup())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
function c210001508.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local dg=Duel.GetMatchingGroup(c210001508.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,tc,tc:GetColumnGroup())
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function c210001508.thidcondition(e,tp)
	return Duel.GetTurnPlayer()~=tp
end
function c210001508.thidtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,210001508) end
end
function c210001508.thidoperation(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(c210001508.thcon)
	e1:SetOperation(c210001508.thop)
	Duel.RegisterEffect(e1,tp)
end
function c210001508.thcon(e,tp)
	return Duel.GetTurnPlayer()==tp
end
function c210001508.thop(e,tp)
	e:Reset()
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,210001508)
	if g and #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end