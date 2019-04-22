--Dark Magic Contract
--scripted by Larry126
function c210002502.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	e1:SetTarget(c210002502.atg)
	c:RegisterEffect(e1)
	--shuffle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4779823,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(TIMING_END_PHASE,TIMING_END_PHASE)
	e2:SetCost(c210002502.cost)
	e2:SetTarget(c210002502.target)
	e2:SetOperation(c210002502.operation)
	c:RegisterEffect(e2)
	--recycle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4779823,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(TIMING_MAIN_END,TIMING_MAIN_END)
	e3:SetCondition(c210002502.condition)
	e3:SetCost(c210002502.cost2)
	e3:SetTarget(c210002502.target2)
	e3:SetOperation(c210002502.operation2)
	c:RegisterEffect(e3) 
end
c210002502.listed_names={46986414,210002502,38033121,30208479,0xa1}
function c210002502.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local e1=c210002502.cost(e,tp,eg,ep,ev,re,r,rp,0) 
		and c210002502.target(e,tp,eg,ep,ev,re,r,rp,0)
	local e2=c210002502.condition(e,tp,eg,ep,ev,re,r,rp,0)
		and c210002502.cost2(e,tp,eg,ep,ev,re,r,rp,0) 
		and c210002502.target2(e,tp,eg,ep,ev,re,r,rp,0)
	local op=2
	if (e1 or e2) and Duel.SelectEffectYesNo(tp,c) then
		if e1 and e2 then
			op=Duel.SelectOption(tp,aux.Stringid(4779823,1),aux.Stringid(4779823,2))
		elseif e1 then
			op=0
		else
			op=1
		end
		if op==0 then
			c210002502.cost(e,tp,eg,ep,ev,re,r,rp,1)
			c210002502.target(e,tp,eg,ep,ev,re,r,rp,1)
			e:SetOperation(c210002502.operation)
		else
			c210002502.condition(e,tp,eg,ep,ev,re,r,rp,1)
			c210002502.cost2(e,tp,eg,ep,ev,re,r,rp,1)
			c210002502.target2(e,tp,eg,ep,ev,re,r,rp,1)
			e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
			e:SetOperation(c210002502.operation2)
		end
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function c210002502.cfilter(c)
	return (c:IsType(TYPE_CONTINUOUS) and c:IsFaceup()) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFacedown()) and c:IsAbleToDeckAsCost()
end
function c210002502.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,210002502)==0 
		and Duel.IsExistingMatchingCard(c210002502.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.RegisterFlagEffect(tp,210002502,RESET_PHASE+PHASE_END,0,1)
	local cg=Duel.SelectMatchingCard(tp,c210002502.cfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoDeck(cg,nil,2,REASON_COST)
end
function c210002502.filter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp) 
		and aux.IsCodeListed(c,46986414)
end
function c210002502.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210002502.filter,tp,LOCATION_DECK,0,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 end
end
function c210002502.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(210002502,0))
	local g=Duel.SelectMatchingCard(tp,c210002502.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		if te:IsActivatable(tp) then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			Duel.RaiseEvent(tc,EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
function c210002502.condition(e,tp,eg,ep,ev,re,r,rp)
	local tn=Duel.GetTurnPlayer()
	local ph=Duel.GetCurrentPhase()
	return tn==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
function c210002502.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.GetFlagEffect(tp,210002502+100)==0 end
	Duel.RegisterFlagEffect(tp,210002502+100,RESET_PHASE+PHASE_END,0,1)
	Duel.SendtoGrave(c,REASON_COST)
end
function c210002502.rfilter(c,tp)
	return c:IsAbleToDeck()
		and (aux.IsCodeListed(c,46986414,38033121,30208479)
		or (c:IsSetCard(0xa1) and c:IsType(TYPE_SPELL))
		or c:IsCode(15256925,76792184,
		7084129,13722870,29436665,
		30603688,35191415,71696014,
		71703785,73752131,75380687,
		92377303,98502113,88619463))
end
function c210002502.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c210002502.rfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(c210002502.rfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c210002502.rfilter,tp,LOCATION_GRAVE,0,1,3,c)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c210002502.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local ct=Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
	if ct>0 then
		Duel.BreakEffect()
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	end
end