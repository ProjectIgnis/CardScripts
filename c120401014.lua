--腐りの呪縛死霊叫
--Cursed Scream of Corruption
--Scripted by Eerie Code
function c120401014.initial_effect(c)
	--to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(120401014,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,120401014+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c120401014.tgcon)
	e1:SetTarget(c120401014.tgtg)
	e1:SetOperation(c120401014.tgop)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401014,2))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,120401014+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c120401014.rmcon)
	e2:SetTarget(c120401014.rmtg)
	e2:SetOperation(c120401014.rmop)
	c:RegisterEffect(e2)
	--change name
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetValue(32274490)
	c:RegisterEffect(e3)
	--wight function
	if not Card.IsWight then
		function Card.IsWight(c)
			return c:IsCode(36021814,40991587,32274490,22339232,57473560,90243945,96383838) or c.is_wight
		end
	end
end
function c120401014.tgcfilter(c)
	return c:IsFaceup() and c:IsWight()
end
function c120401014.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c120401014.tgcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c120401014.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
function c120401014.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c120401014.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c120401014.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,c120401014.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_GRAVE)
		and tc:IsCode(32274490) then
		local g=Duel.GetMatchingGroup(c120401014.tgfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(120401014,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
function c120401014.rmcfilter(c)
	return c:IsFaceup() and c:IsCode(32274490)
end
function c120401014.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c120401014.rmcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c120401014.rmfilter(c)
	return c:IsCode(32274490) and c:IsAbleToRemove()
end
function c120401014.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c120401014.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_ONFIELD)
end
function c120401014.rmop(e,tp,eg,ep,ev,re,r,rp)
	local gg=Duel.GetMatchingGroup(c120401014.rmfilter,tp,LOCATION_GRAVE,0,nil)
	local og=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if gg:GetCount()*og:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=gg:Select(tp,1,gg:GetCount(),nil)
	local oc=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if oc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=og:Select(tp,1,oc,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
