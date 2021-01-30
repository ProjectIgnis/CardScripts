-- 鋼機神ミラーイノベイター
--Steeltek Deity Mirror Innovator

local s,id=GetID()
function s.initial_effect(c)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil,e:GetHandler():GetRace()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.filter(c,race)
	return c:IsFaceup() and c:IsRace(race) and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	--Effect
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,3,nil,c:GetRace())
		Duel.HintSelection(g)
		local atk=0
		if #g>0 then
			local bc=g:GetFirst()
			for bc in aux.Next(g) do
				atk=atk+(bc:GetLevel()*100)
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			e1:SetValue(atk)
			c:RegisterEffect(e1)
			Duel.BreakEffect()
			local temp=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			if temp==1 then
				--Piercing
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(3208)
				e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_PIERCE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e2)
			end
		end
	end
end