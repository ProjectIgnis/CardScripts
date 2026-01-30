--道化の一座『怪演』
--Clown Crew "Soiree"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects (but you can only use each of these effects of "Clown Crew "Soiree"" once per turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During the Main Phase: You can banish this card from your GY; immediately after this effect resolves, Tribute Summon 1 "Clown Crew" monster face-up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tribsumtg)
	e2:SetOperation(s.tribsumop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CLOWN_CREW}
function s.spfilter(c,e,tp,mmz_chk)
	if not (c:IsSetCard(SET_CLOWN_CREW) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return mmz_chk
	elseif c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_CLOWN_CREW) and c:IsMonster() and c:IsAbleToHand()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost_skip=e:GetLabel()~=-100
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+1))
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then e:SetLabel(0) return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.pendlinkfilter(c)
	return (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()) or c:IsLinkMonster()
end
function s.rescon(mmz_ct,linkmz_ct)
	return	function(sg,e,tp,mg)
				return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=mmz_ct
					and sg:FilterCount(s.pendlinkfilter,nil)<=linkmz_ct
			end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		--You cannot activate the effects of monsters Special Summoned from the Deck or Extra Deck until the end of the next turn after this card resolves
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
	local op=e:GetLabel()
	if op==1 then
		--● Special Summon up to 2 "Clown Crew" monsters from your Deck and/or Extra Deck, ignoring their Summoning conditions
		local mmz_ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local emz_ct=Duel.GetLocationCountFromEx(tp,tp,nil,nil,ZONES_EMZ)
		local linkmz_ct=Duel.GetLocationCountFromEx(tp,tp)
		local ft=math.min(mmz_ct+emz_ct,2)
		if ft<=0 then return end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil,e,tp,mmz_ct>0)
		if #g==0 then return end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(mmz_ct,linkmz_ct),1,tp,HINTMSG_SPSUMMON)
		if #sg==0 then return end
		local fup,fdown=sg:Split(s.pendlinkfilter,nil)
		local fdown_main,fdown_ex=fdown:Split(Card.IsLocation,nil,LOCATION_DECK)
		local priority_0,priority_1
		if linkmz_ct<mmz_ct then
			priority_0=fup
			priority_1=fdown_main
		else
			priority_0=fdown_main
			priority_1=fup
		end
		for prio0_c in priority_0:Iter() do
			Duel.SpecialSummonStep(prio0_c,0,tp,tp,true,false,POS_FACEUP)
		end
		for prio1_c in priority_1:Iter() do
			Duel.SpecialSummonStep(prio1_c,0,tp,tp,true,false,POS_FACEUP)
		end
		for fdown_ex_c in fdown_ex:Iter() do
			Duel.SpecialSummonStep(fdown_ex_c,0,tp,tp,true,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	elseif op==2 then
		--● Add 1 "Clown Crew" monster from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsOnField() and rc:IsSummonLocation(LOCATION_DECK|LOCATION_EXTRA)
end
function s.tribsumfilter(c)
	return c:IsSetCard(SET_CLOWN_CREW) and c:IsSummonable(true,nil,1)
end
function s.tribsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tribsumfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.tribsumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.tribsumfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if sc then
		Duel.Summon(tp,sc,true,nil,1)
	end
end