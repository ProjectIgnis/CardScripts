--Forced Activation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.filter(c,e,tp,eg,ep,ev,re,r,rp)
	local te=c:GetActivateEffect()
	if not te or not (te:IsActivatable(c:GetControler()) or c:IsStatus(STATUS_SET_TURN)) then return false end
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	if te:GetCode()==EVENT_FREE_CHAIN then
		return (not condition or condition(te,c:GetControler(),eg,ep,ev,re,r,rp)) 
			and (not cost or cost(te,c:GetControler(),eg,ep,ev,re,r,rp,0))
			and (not target or target(te,c:GetControler(),eg,ep,ev,re,r,rp,0))
	elseif te:GetCode()==EVENT_CHAINING then
		return (not condition or condition(te,c:GetControler(),Group.FromCards(e:GetHandler()),tp,0,e,r,tp)) 
			and (not cost or cost(te,c:GetControler(),Group.FromCards(e:GetHandler()),tp,0,e,r,tp,0))
			and (not target or target(te,c:GetControler(),Group.FromCards(e:GetHandler()),tp,0,e,r,tp,0))
	else
		local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
		return res and (not condition or condition(te,c:GetControler(),teg,tep,tev,tre,tr,trp)) 
			and (not cost or cost(te,c:GetControler(),teg,tep,tev,tre,tr,trp,0))
			and (not target or target(te,c:GetControler(),teg,tep,tev,tre,tr,trp,0))
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Duel.ChangePosition(tc,0,0,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
		if tc:IsLocation(LOCATION_SZONE) and s.filter(tc,e,tp,eg,ep,ev,re,r,rp) then
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			Duel.ClearTargetCard()
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
				tc:CancelToGrave(false)
			end
			if te:GetCode()==EVENT_FREE_CHAIN then
				if co then co(te,tc:GetControler(),eg,ep,ev,re,r,rp,1) end
				if tg then tg(te,tc:GetControler(),eg,ep,ev,re,r,rp,1) end
			elseif te:GetCode()==EVENT_CHAINING then
				if co then co(te,tc:GetControler(),Group.FromCards(c),tp,0,e,r,tp,1) end
				if tg then tg(te,tc:GetControler(),Group.FromCards(c),tp,0,e,r,tp,1) end
			else
				local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
				if co then co(te,tc:GetControler(),teg,tep,tev,tre,tr,trp,1) end
				if tg then tg(te,tc:GetControler(),teg,tep,tev,tre,tr,trp,1) end
			end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
			if te:GetCode()==EVENT_FREE_CHAIN then
				if op then op(te,tc:GetControler(),eg,ep,ev,re,r,rp) end
			elseif te:GetCode()==EVENT_CHAINING then
				if op then op(te,tc:GetControler(),Group.FromCards(c),tp,0,e,r,tp) end
			else
				local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
				if op then op(te,tc:GetControler(),teg,tep,tev,tre,tr,trp) end
			end
			if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
				Duel.Equip(tp,tc,g:GetFirst())
			end
			tc:ReleaseEffectRelation(te)
			if etc then	
				etc=g:GetFirst()
				while etc do
					etc:ReleaseEffectRelation(te)
					etc=g:GetNext()
				end
			end
		end
	end
end
