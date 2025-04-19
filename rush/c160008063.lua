--聖なる装甲 －炸裂フォース－
--Sakuretsu Force
local s,id=GetID()
function s.initial_effect(c)
	--Opponent's attacking monster loses 400 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetAttacker()
	return tg and tg:IsFaceup() and tg:IsControler(1-tp)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.HintSelection(g,true)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		local tc=Duel.GetAttacker()
		if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-500)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,56120475),tp,LOCATION_GRAVE,0,1,nil)
				and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
				if #g>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
					sg=g:Select(tp,1,2,nil)
					sg=sg:AddMaximumCheck()
					Duel.Destroy(sg,REASON_EFFECT)
				end
			end
			
		end
	end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsPosition(POS_FACEUP_ATTACK)
end