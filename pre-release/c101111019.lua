--呪眼の眷属 バジリコック
--Basiltrice, Familiar of the Evil Eye
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Link Summon 1 "Evil Eye" monster during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.lnktg)
	e2:SetOperation(s.lnkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_EVIL_EYE}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_EVIL_EYE),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
function s.eqfilter(c)
	return c:IsSetCard(SET_EVIL_EYE) and c:IsSpell() and c:IsType(TYPE_EQUIP)
end
function s.lnkfilter(c)
	return c:IsSetCard(SET_EVIL_EYE) and c:IsLinkSummonable()
end
function s.lnktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local e1,e2 = s.tempregister(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=Duel.IsExistingMatchingCard(s.lnkfilter,tp,LOCATION_EXTRA,0,1,nil)
		e1:Reset()
		e2:Reset()
		return res
	end
	e1:Reset()
	e2:Reset()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lnkop(e,tp,eg,ep,ev,re,r,rp,chk)
	local e1,e2 = s.tempregister(e,tp,eg,ep,ev,re,r,chk)
	local g=Duel.GetMatchingGroup(s.lnkfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if not sc then
			e1:Reset()
			e2:Reset()
			return
		end
		Duel.LinkSummon(tp,sc)
		--Manually reset e1 and e2 when the monster would be Link Summoned
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_SPSUMMON)
		e3:SetOperation(s.resetop)
		e3:SetLabelObject({e1,e2})
		Duel.RegisterEffect(e3,tp)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e1,e2=table.unpack(e:GetLabelObject())
	e1:Reset()
	e2:Reset()
	e:Reset()
end
function s.tempregister(e,tp,eg,ep,ev,re,r,rp,chk)
	--Can treat "Evil Eye" Equip cards as Link Material if using this effect
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,0)
	e1:SetOperation(aux.TRUE)
	e1:SetValue(s.extraval)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCondition(s.addtypecon)
	e2:SetTarget(aux.TargetBoolFunction(s.eqfilter))
	e2:SetValue(TYPE_MONSTER)
	Duel.RegisterEffect(e2,tp)
	return e1,e2
end
function s.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_EVIL_EYE) and c:IsSpell() and c:IsType(TYPE_EQUIP)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc:IsSetCard(SET_EVIL_EYE)) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end
function s.addtypecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end