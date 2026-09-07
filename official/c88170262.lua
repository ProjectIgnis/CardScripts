--キラーチューン・リミックス
--Kewl Tune Remix
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: "Kewl Tune Mix" + 1+ Tuners
	Synchro.AddProcedure(c,aux.FALSE,1,1,s.tunerfilter,1,99,aux.FilterSummonCode(16509007))
	--Gains 1500 ATK while your opponent has a Tuner in their field or GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1500)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_TUNER),e:GetHandlerPlayer(),0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end)
	c:RegisterEffect(e1)
	--Take 2 non-Synchro Tuners from your GY, add 1 of them to your hand, and if you do, Special Summon the other, then immediately after this effect resolves, you can Synchro Summon 1 Tuner
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.thsptg)
	e2:SetOperation(s.thspop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--Multiple tuners
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	c:RegisterEffect(e4)
end
s.listed_names={16509007} --"Kewl Tune Mix"
s.material={16509007}
function s.tunerfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_TUNER,scard,sumtype,tp) or c:IsHasEffect(EFFECT_CAN_BE_TUNER)
end
function s.thspfilter(c,e,tp,exc)
	return c:IsType(TYPE_TUNER) and not c:IsType(TYPE_SYNCHRO)
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.validselection(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and sg:IsExists(Card.IsAbleToHand,1,c)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.validselection,1,nil,e,tp,sg)
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thspfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return #g>=2 and Duel.GetMZoneCount(tp,e:GetHandler())>0
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synchfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSynchroSummonable()
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local thsp_g=Duel.GetMatchingGroup(s.thspfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #thsp_g<2 then return end
	local g=aux.SelectUnselectGroup(thsp_g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,1))
	if #g<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local thc=g:FilterSelect(tp,s.validselection,1,1,nil,e,tp,g):GetFirst()
	local sc=(g-thc):GetFirst()
	if thc and Duel.SendtoHand(thc,nil,REASON_EFFECT)>0 and thc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,thc)
		Duel.ShuffleHand(tp)
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local synchg=Duel.GetMatchingGroup(s.synchfilter,tp,LOCATION_EXTRA,0,nil)
			if #synchg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local synchc=synchg:Select(tp,1,1,nil):GetFirst()
			if synchc then
				Duel.SynchroSummon(tp,synchc)
			end
		end
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(function(c) return c:IsType(TYPE_TUNER) or c:IsHasEffect(EFFECT_CAN_BE_TUNER) end,2,nil) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_MULTIPLE_TUNERS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD)|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end