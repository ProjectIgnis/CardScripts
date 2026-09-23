--Ｖアンブラル
--V Umbral Horror
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can add 1 "Umbral Horror" monster from your Deck to your hand, except "V Umbral Horror"
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.thtg)
	e1a:SetOperation(s.thop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--You can banish this card from your GY, then target 1 "Masquerade" Xyz Monster you control; Special Summon from your Extra Deck, 1 "Number" monster that is 1 Rank higher than that monster you control, by using it as material (this is treated as an Xyz Summon, transfer its materials)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_UMBRAL_HORROR,SET_MASQUERADE,SET_NUMBER}
s.listed_names={id}
function s.thfilter(c)
	return c:IsSetCard(SET_UMBRAL_HORROR) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.masqueradefilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and c:IsSetCard(SET_MASQUERADE) and c:IsXyzMonster() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.numberspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
end
function s.numberspfilter(c,e,tp,mc,rank)
	return c:IsSetCard(SET_NUMBER) and c:IsXyzMonster() and c:IsRank(rank) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and mc:IsCanBeXyzMaterial(c,tp) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.masqueradefilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.masqueradefilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.masqueradefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
		if #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=Duel.SelectMatchingCard(tp,s.numberspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1):GetFirst()
		if xyz then
			xyz:SetMaterial(tc)
			Duel.Overlay(xyz,tc)
			if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)==0 then return end
			xyz:CompleteProcedure()
		end
	end
end