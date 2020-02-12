--Supreme King Wrath
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_names={13331639,43387895,70771599,42160203,96733134}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	s[ep]=s[ep]+ev
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and s[tp]>=2000 
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,13331639)
end
function s.desfilter(c)
	return c:IsFacedown() or not c:IsCode(13331639)
end
function s.spfilterchk(c,g,sg,code,...)
	if not c:IsCode(code) then return false end
	if ... then
		g:AddCard(c)
		local res=g:IsExists(s.spfilterchk,1,sg,g,sg,...)
		g:RemoveCard(c)
		return res
	else return true end
end
function s.rescon(mft,exft,ft,ect)
	return	function(sg,e,tp,mg)
				local exct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
				local mct=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
				return (not ect or ect>=exct) and exft>=exct and mft>=mct and ft>=#sg 
					and sg:IsExists(s.spfilterchk,nil,sg,Group.CreateGroup(),43387895,70771599,42160203,96733134)
			end
end
function s.spfilter(c,e,tp)
	return c:IsCode(43387895,70771599,42160203,96733134) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
	local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)+dg:FilterCount(function(c) return c:GetSequence()<5 end,nil)
		local ftt=Duel.GetUsableMZoneCount(tp)
		local ftex=Duel.GetLocationCountFromEx(tp,tp,dg)
		return sg:IsExists(Card.IsCode,1,nil,43387895) and sg:IsExists(Card.IsCode,1,nil,70771599) and sg:IsExists(Card.IsCode,1,nil,42160203) and sg:IsExists(Card.IsCode,1,nil,96733134)
			and aux.SelectUnselectGroup(sg,e,tp,4,4,s.rescon(ft,ftex,ftt,ect),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if Duel.Destroy(dg,REASON_EFFECT)>0 or #dg==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
		local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ftt=Duel.GetUsableMZoneCount(tp)
		local ftex=Duel.GetLocationCountFromEx(tp)
		if ftt<=3 then return end
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
		if #g<=3 then return end
		local spg=aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon(ft,ftex,ftt,ect),1,tp,HINTMSG_SPSUMMON)
		if #spg<=3 then return end
		if Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP) > 0 then
			for tc in aux.Next(spg) do
				if tc:IsLocation(LOCATION_MZONE) then
					s.disop(tc,e:GetHandler())
				end
			end
		else
			return
		end
		local og=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,69610326)
		local drg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,42160203)
		if #og>1 and #drg>0 and Duel.SelectYesNo(tp,aux.Stringid(12744567,0)) then
			Duel.BreakEffect()
			if #drg>1 then
				drg=drg:Select(tp,1,1,nil)
			end
			Duel.HintSelection(drg)
			local sog=og:Select(tp,2,2,nil)
			Duel.Overlay(drg:GetFirst(),sog)
		end
	end
end
function s.disop(tc,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
end
