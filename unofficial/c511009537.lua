--覇王の逆鱗 (Anime)
--Supreme Rage (Anime)
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
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
s.listed_names={CARD_ZARC,43387895,70771599,42160203,96733134}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	s[ep]=s[ep]+ev
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and s[tp]>=2000
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_ZARC),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.desfilter(c)
	return c:IsFacedown() or not c:IsCode(CARD_ZARC)
end
function s.exfilter1(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ)
end
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
function s.rescon(mft,exft1,exft2)
	return function(sg,e,tp,mg)
				local exct1=sg:FilterCount(s.exfilter1,nil,LOCATION_EXTRA)
				local exct2=sg:FilterCount(s.exfilter2,nil,LOCATION_EXTRA)
				local mct=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
				local groupcount=#sg
				local classcount=sg:GetClassCount(Card.GetCode)
				local res=(exft2>=(exct1+exct2) or Duel.IsDuelType(DUEL_FSX_MMZONE)
					and exft1>=exct1 and exft2>=exct2) and mft>=mct and classcount==groupcount
				return res, not res
			end
end
function s.spfilter(c,e,tp)
	return c:IsCode(43387895,70771599,42160203,96733134) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
		if #dg==0 then return false end
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,nil,e,tp)
		if #sg<4 or not (sg:IsExists(Card.IsCode,1,nil,43387895) and sg:IsExists(Card.IsCode,1,nil,70771599)
			and sg:IsExists(Card.IsCode,1,nil,42160203) and sg:IsExists(Card.IsCode,1,nil,96733134)) then return false end
		local ft=Duel.GetMZoneCount(tp,dg)
		local ftex1=Duel.GetLocationCountFromEx(tp,tp,dg,TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ)
		local ftex2=Duel.GetLocationCountFromEx(tp,tp,dg,TYPE_PENDULUM|TYPE_LINK)
		local ect=aux.CheckSummonGate(tp)
		if ect then
			ftex1=math.min(ect,ftex1)
			ftex2=math.min(ect,ftex2)
		end
		return aux.SelectUnselectGroup(sg,e,tp,4,4,s.rescon(ft,ftex1,ftex2),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if Duel.Destroy(dg,REASON_EFFECT)>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		local ftt=Duel.GetUsableMZoneCount(tp)
		if ftt<4 then return end
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,nil,e,tp)
		if #sg<4 or not (sg:IsExists(Card.IsCode,1,nil,43387895) and sg:IsExists(Card.IsCode,1,nil,70771599)
			and sg:IsExists(Card.IsCode,1,nil,42160203) and sg:IsExists(Card.IsCode,1,nil,96733134)) then return end
		local ft=Duel.GetMZoneCount(tp)
		local ftex1=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ)
		local ftex2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM|TYPE_LINK)
		local ect=aux.CheckSummonGate(tp)
		if ect then
			ftex1=math.min(ect,ftex1)
			ftex2=math.min(ect,ftex2)
		end
		local spg=aux.SelectUnselectGroup(sg,e,tp,4,4,s.rescon(ft,ftex1,ftex2),1,tp,HINTMSG_SPSUMMON)
		if #spg<4 then return end
		if Duel.SpecialSummon(spg,0,tp,tp,true,false,POS_FACEUP)>0 then
			local spog=Duel.GetOperatedGroup()
			local c=e:GetHandler()
			for sc in aux.Next(spog) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
				sc:RegisterEffect(e1,true)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				sc:RegisterEffect(e2,true)
			end
			local og=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,nil,69610326)
			local drg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,42160203),tp,LOCATION_MZONE,0,nil)
			if #og>1 and #drg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				if #drg>1 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
					drg=drg:Select(tp,1,1,nil)
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
				local sog=og:Select(tp,2,2,nil)
				Duel.Overlay(drg:GetFirst(),sog)
			end
		end
	end
end