--天魔神 シドヘルズ
--Sky Scourge Cidhels
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be special summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	--Apply an effect, based on the tributed monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)return e:GetHandler():IsTributeSummoned()end)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Check the type/attribute of the monster for its tribute summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
	--Check the type/attribute of the monster for its tribute summon
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.filter1,1,nil) then
		e:GetLabelObject():SetLabel(1)
	elseif g:IsExists(s.filter2,1,nil) then
		e:GetLabelObject():SetLabel(2)
	else e:GetLabelObject():SetLabel(0) end
end
	--Various filters
function s.filter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
function s.filter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
end
function s.thfilter(c)
	return (s.filter1(c) or s.filter2(c)) and c:IsAbleToHand()
end
function s.tgfilter1(c)
	return s.filter1(c) and c:IsAbleToGrave()
end
function s.tgfilter2(c)
	return s.filter2(c) and c:IsAbleToGrave()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local var=e:GetLabel()
	if chk==0 then
		if var==1 then
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		elseif var==2 then
			return Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_DECK,0,1,nil)
			or Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_DECK,0,1,nil)
		end
	end
	if var==1 then
		e:SetOperation(s.thop)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif var==2 then
		e:SetOperation(s.tgop)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
	--Add 1 LIGHT fairy or 1 DARK fiend from deck
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
	--The monsters to send to GY differs from each other
function s.ctcheck(sg,e,tp)
	return sg:GetClassCount(Card.GetAttribute)==#sg and sg:GetClassCount(Card.GetRace)==#sg
end
	--Send 1 LIGHT fairy and/or 1 DARK fiend from deck to GY
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g1,g2=Duel.GetMatchingGroup(s.tgfilter1,tp,LOCATION_DECK,0,nil),Duel.GetMatchingGroup(s.tgfilter2,tp,LOCATION_DECK,0,nil)
	g1:Merge(g2)
	local sg=aux.SelectUnselectGroup(g1,e,tp,1,2,s.ctcheck,1,tp,HINTMSG_TOGRAVE)
	if #sg>0 then Duel.SendtoGrave(sg,REASON_EFFECT) end
end