--宝玉獣 サファイア・ペガサス (Anime)
--Crystal Beast Sapphire Pegasus (Anime)
--Scripted by Kevdaplog
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Crystal Beast" monster from your hand, Deck or GY in  your Spell & Trap Zone as a Cont. Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7093411,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(s.placetg)
	e1:SetOperation(s.placeop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Place this card in Spell & Trap Zone instead of sending to GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e4:SetCondition(s.replacecon)
	e4:SetOperation(s.replaceop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_CRYSTAL_BEAST}
function s.placefilter(c)
	return c:IsSetCard(SET_CRYSTAL_BEAST) and not c:IsForbidden()
end
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.placefilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+CARD_CRYSTAL_TREE,e,0,tp,0,0)
	end
end
function s.replacecon(e)
	local c=e:GetHandler()
	return ((c:IsFaceup() and c:IsLocation(LOCATION_MZONE)) or (c:IsLocation(LOCATION_HAND|LOCATION_DECK))) and c:IsReason(REASON_DESTROY)
end
function s.replaceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	Duel.RaiseEvent(c,EVENT_CUSTOM+CARD_CRYSTAL_TREE,e,0,tp,0,0)
end