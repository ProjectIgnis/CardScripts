--星霜の魔術師－アストログラフ・マジシャン
--Astrograph Sorcerer, the Star Magician
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--During your Main Phase: You can destroy this card, and if you do, place 1 Pendulum Monster whose Pendulum Scale is 1 from your hand or Deck in your Pendulum Zone, except "Astrograph Sorcerer, the Star Magician", but it cannot activate its Pendulum Effects this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--If a face-up Monster Card(s) you control is destroyed by battle or card effect: You can Special Summon this card from your hand, then you can Special Summon 1 of those destroyed monsters from your GY or face-up Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Keep track of the destroyed monsters
	aux.GlobalCheck(s,function()
		s.desgroup=Group.CreateGroup()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.desgroupregop)
		Duel.RegisterEffect(ge1,0)
	end)
	--During the Main Phase (Quick Effect): You can Tribute this card, then you can Fusion Summon 1 Dragon Fusion Monster from your Extra Deck, by shuffling its materials from your field and/or face-up Extra Deck into the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_RELEASE+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function() return Duel.IsMainPhase() end)
	e3:SetTarget(s.tribtg)
	e3:SetOperation(s.tribop)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.plfilter(c)
	return c:IsPendulumMonster() and c:IsScale(1) and not c:IsCode(id) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 and Duel.CheckPendulumZones(tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc and Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
			--It cannot activate its Pendulum Effects this turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3302)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1)
		end
	end
end
function s.spconfilter(c)
	return c:IsMonsterCard() and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.desgroupregop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.spconfilter,nil)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		if Duel.GetCurrentChain()==0 then s.desgroup:Clear() end
		s.desgroup:Merge(tg)
		s.desgroup:Remove(function(c) return not c:HasFlagEffect(id) end,nil)
		if tg:IsExists(Card.IsPreviousControler,1,nil,0) then
			local g=s.desgroup:Filter(Card.IsPreviousControler,nil,0)
			Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,rp,0,ev)
		end
		if tg:IsExists(Card.IsPreviousControler,1,nil,1) then
			local g=s.desgroup:Filter(Card.IsPreviousControler,nil,1)
			Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,rp,1,ev)
		end
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return ep==tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local g=s.desgroup:Filter(s.spconfilter,nil)
	e:SetLabelObject(g)
	for ec in g:Iter() do
		ec:CreateEffectRelation(e)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spfilter(c,e,tp,mmz_chk)
	if not (c:IsControler(tp) and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return mmz_chk
	elseif c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local g=e:GetLabelObject():Filter(aux.NecroValleyFilter(s.spfilter),nil,e,tp,mmz_chk)
		if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.tribtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasableByEffect() end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD|LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.tribop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Release(c,REASON_EFFECT)>0 then
		local fusion_params={
				fusfilter=function(c) return c:IsRace(RACE_DRAGON) end,
				extraop=Fusion.ShuffleMaterial,
				matfilter=Fusion.OnFieldMat,
				extrafil=function(e,tp,mg)
						return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeck),tp,LOCATION_EXTRA,0,nil)
					end
			}
		if Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end