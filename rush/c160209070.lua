--ドリームチケット
--Dream Ticket
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_PRIMA_GUITARNA,160002025}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_PRIMA_GUITARNA,160002025)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,1,nil)
			Duel.HintSelection(sg,true)
			if Duel.Destroy(sg,REASON_EFFECT)>0 then
				--Prevent non-Psychic or Omega Psychic from attacking
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_ATTACK)
				e1:SetTargetRange(LOCATION_MZONE,0)
				e1:SetTarget(function(_,c) return not (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_OMEGAPSYCHIC)) end)
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end