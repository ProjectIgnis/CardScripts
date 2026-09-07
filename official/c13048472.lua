--儀式の下準備
--Pre-Preparation of Rites
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Ritual Spell from your Deck to your hand, and add 1 Ritual Monster from your Deck or GY to your hand whose name is mentioned on that Ritual Spell. You can only activate 1 "Pre-Preparation of Rites" per turn
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
function s.spellfilter(c,tp)
	return c:IsRitualSpell() and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,c)
end
function s.monsterfilter(c,ritual_spell)
	return c:IsRitualMonster() and ritual_spell:ListsCode(c:GetCode()) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.rescon(sg,e,tp,mg)
	local ritual_spell=sg:Filter(Card.IsRitualSpell,nil):GetFirst()
	return ritual_spell and sg:IsExists(s.monsterfilter,1,nil,ritual_spell),not ritual_spell
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spellfilter,tp,LOCATION_DECK,0,nil,tp)
	if #g==0 then return end
	g:Merge(Duel.GetMatchingGroup(aux.NecroValleyFilter(aux.AND(Card.IsRitualMonster,Card.IsAbleToHand)),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil))
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #sg==2 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end