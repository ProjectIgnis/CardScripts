--ヴァルモニカ・インヴィターレ
--Vaalmonica Invitare
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VAALMONICA}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VAALMONICA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.nonpendfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VAALMONICA) and not c:IsType(TYPE_PENDULUM)
end
function s.cfilter(c)
	return c:IsSetCard(SET_VAALMONICA) and c:IsMonster() and c:IsType(TYPE_PENDULUM)
		and (c:IsAbleToHand() or not c:IsForbidden())
end
function s.extrachk(c,sg)
	return c:IsAbleToHand() and sg:IsExists(aux.TRUE,1,c)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)>=2 and sg:IsExists(s.extrachk,1,nil,sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		if b1 then return true end
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
		local b2=Duel.IsExistingMatchingCard(s.nonpendfilter,tp,LOCATION_MZONE,0,1,nil)
			and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
		return b1 or b2
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
	local b2=Duel.IsExistingMatchingCard(s.nonpendfilter,tp,LOCATION_MZONE,0,1,nil)
			and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	if op==1 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			--Cannot activate effects of monsters, except "Vaalmonica" monsters
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.actfilter)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
		--Special Summon 1 "Vaalmonica" monster from your Deck
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sc>0 then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--Take 2 "Vaalmonica" Pendulum Monsters from your Deck
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,4))
		if #sg~=2 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local thg=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		Duel.SendtoExtraP(sg:Sub(thg),tp,REASON_EFFECT)
		Duel.SendtoHand(thg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,thg)
	end
end
function s.actfilter(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsOnField() and not rc:IsSetCard(SET_VAALMONICA)
end