--香水戦術
--Aroma Strategy
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Once per turn: You can declare 1 card name; reveal the top card of your Deck, and if it is the declared card, you can apply this effect based on its card type. If it is not, destroy this card
	--● Monster: Special Summon it
	--● Spell/Trap: Set it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SET+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.revealtg)
	e1:SetOperation(s.revealop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If this card is destroyed by card effect: You can Special Summon 1 "Harpie" monster from your Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsReason(REASON_EFFECT)
	end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_HARPIE}
function s.revealtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,1)
	if chk==0 then return #g>0 and not g:GetFirst():IsPublic() end
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local declared_code=Duel.AnnounceCard(tp,s.announce_filter)
	e:GetChainData().declared_code=declared_code
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
end
function s.revealop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0 then return end
	local tc=Duel.ConfirmDecktop(tp,1):GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	local declared_code=e:GetChainData().declared_code
	if tc:IsCode(declared_code) then
		--If it is the declared card, you can apply this effect based on its card type
		--● Monster: Special Summon it
		local apply_monster_chk=tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		--● Spell/Trap: Set it
		local apply_spelltrap_chk=tc:IsSpellTrap() and tc:IsSSetable()
		if (apply_monster_chk or apply_spelltrap_chk)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.DisableShuffleCheck()
			if apply_monster_chk then
				--● Monster: Special Summon it
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			elseif apply_spelltrap_chk then
				--● Spell/Trap: Set it
				Duel.SSet(tp,tc)
			end
		end
	elseif c:IsRelateToEffect(e) then
		--If it is not, destroy this card
		Duel.Destroy(c,REASON_EFFECT)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_HARPIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end