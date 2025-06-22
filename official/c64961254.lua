--女神ヴェルダンディの導き
--Goddess Verdande's Guidance
--Scripted by Eerie Code and AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: If all monsters you control are "Valkyrie" monsters (min. 1), you can add 1 "Goddess Urd's Verdict" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Reveal the top card of your opponent's Deck and if it was the declared type, they Set it to their field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.revealtg)
	e2:SetOperation(s.revealop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VALKYRIE}
s.listed_names={91969909} --"Goddess Urd's Verdict"
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsCode(91969909) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(aux.NOT(aux.FaceupFilter(Card.IsSetCard,SET_VALKYRIE)),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.revealtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	Duel.SetTargetParam(Duel.SelectOption(tp,DECLTYPE_MONSTER,DECLTYPE_SPELL,DECLTYPE_TRAP))
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.revealop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,0,LOCATION_DECK)<=0 then return end
	Duel.DisableShuffleCheck()
	Duel.ConfirmDecktop(1-tp,1)
	local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	if not tc then return end
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if (opt==0 and tc:IsMonster()
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)) then
		Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(tp,tc)
	elseif ((opt==1 and tc:IsSpell()) or (opt==2 and tc:IsTrap())) and tc:IsSSetable(false,1-tp) then
		Duel.DisableShuffleCheck()
		Duel.SSet(1-tp,tc)
	else
		Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
		Duel.ConfirmCards(tp,tc)
		Duel.ShuffleHand(1-tp)
	end
end