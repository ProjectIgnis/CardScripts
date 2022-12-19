--刀皇－都牟羽沓薙
--Sword Emperor - Tsumuhakutsunagi
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Can be Tribute Summoned by Tributing 1 Normal Summoned/Set monster
	aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),aux.FilterBoolFunction(Card.IsSummonType,SUMMON_TYPE_NORMAL))
	aux.AddNormalSetProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),aux.FilterBoolFunction(Card.IsSummonType,SUMMON_TYPE_NORMAL))
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Opponent can send cards to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_REMOVED|LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		local deck1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local deck2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		local ct=math.min(#g,deck1,deck2)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,ct,nil)
		local oc=Duel.SendtoGrave(sg,REASON_EFFECT)
		if oc>0 then
			local turn_p=Duel.GetTurnPlayer()
			Duel.Draw(turn_p,oc,REASON_EFFECT)
			Duel.Draw(1-turn_p,oc,REASON_EFFECT)
		end
	end
	--Shuffle all cards that are banished, on the field, and in the GYs into the Deck
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.tdop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)	
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_ONFIELD|LOCATION_REMOVED|LOCATION_GRAVE 
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,loc,loc,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end