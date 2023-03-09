--Voici la Carte～メニューはこちら～
--Voici la Carte - Here is the Menu
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Take 2 "Nouvellez" monsters and make the opponent select 1 of them to add to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NOUVELLEZ}
s.listed_names={100430037,100430038} -- Recette de Poisson - Fish Recipe, Recette de Viande - Meat Recipe
function s.revfilter(c)
	return c:IsSetCard(SET_NOUVELLEZ) and c:IsMonster() and c:IsAbleToHand() and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_DECK,0,nil)
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,1))
	local g=sg:Select(1-tp,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ShuffleDeck(tp)
		local rac=g:GetFirst():GetRace()
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,rac)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,rac)
			if #tc>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
end
function s.thfilter(c,rac)
	if not c:IsAbleToHand() then return false end
	if rac==RACE_BEASTWARRIOR then
		return c:IsCode(100430037)
	elseif rac==RACE_WARRIOR then
		return c:IsCode(100430038)
	end
end