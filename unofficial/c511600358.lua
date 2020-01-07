--ディスコネクト・リンカー
--Disconnect Linker
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsLinkBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
function s.spfilter(c,e,tp)
	return s.filter(c,e,tp) and Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,c,tp)
end
function s.lkfilter(c,mc,tp)
	return c:IsType(TYPE_LINK) and c:IsLink(1)
		and (not mc or mc:IsCanBeLinkMaterial(c,tp))
		and c:IsSpecialSummonable(SUMMON_TYPE_LINK)
end
function s.extramat(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if not summon_type==SUMMON_TYPE_LINK then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local c=e:GetHandler()
		local og=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
		local oeff={}
		for oc in aux.Next(og) do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetRange(LOCATION_GRAVE)
			e2:SetCode(EFFECT_EXTRA_MATERIAL)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetTargetRange(1,0)
			e2:SetValue(s.extramat)
			oc:RegisterEffect(e2,true)
			table.insert(oeff,e2)
		end
		local res=chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc)
		for _,oe in ipairs(oeff) do
			oe:Reset()
		end
		return res
	end
	local c=e:GetHandler()
	local og=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local oeff={}
	for oc in aux.Next(og) do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCode(EFFECT_EXTRA_MATERIAL)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetValue(s.extramat)
		oc:RegisterEffect(e2,true)
		table.insert(oeff,e2)
	end
	if chk==0 then
		local res=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		for _,oe in ipairs(oeff) do
			oe:Reset()
		end
		return res
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	for _,oe in ipairs(oeff) do
		oe:Reset()
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
		local oeff={}
		Duel.GetMatchingGroup(Card.IsType,tp,0xff,0xff,tc,TYPE_MONSTER):ForEach(function(oc)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e3:SetValue(1)
			oc:RegisterEffect(e3,true)
			table.insert(oeff,e3)
		end)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc,tp):GetFirst()
		if sc then
			Duel.SpecialSummonRule(tp,sc,SUMMON_TYPE_LINK)
			local e4=Effect.CreateEffect(c)
			e4:SetDescription(aux.Stringid(id,1))
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_IMMUNE_EFFECT)
			e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e4:SetRange(LOCATION_MZONE)
			e4:SetValue(s.efilter)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			e4:SetOwnerPlayer(tp)
			sc:RegisterEffect(e4)
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD)
			e5:SetCode(EFFECT_CANNOT_ATTACK)
			e5:SetRange(LOCATION_MZONE)
			e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e5:SetTarget(s.tg)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e5)
		end
		for _,oe in ipairs(oeff) do
			oe:Reset()
		end
	end
end
function s.tg(e,c)
	return c:GetSequence()>4
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
