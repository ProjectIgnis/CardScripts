--真超量機神王ブラスター・マグナ
--True Super Quantal Mech King Blaster Magna
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.matcheck)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.incon)
	e1:SetValue(s.inval)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0xdc}
function s.matcheck(g,lc,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xdc,lc,SUMMON_TYPE_LINK,tp)
end
function s.incon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.inval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
function s.drcfilter(c,tp,lg)
	return c:IsSetCard(0xdc) and c:IsType(TYPE_XYZ) and c:IsPreviousLocation(LOCATION_EXTRA)
		and lg:IsContains(c) and not Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_MZONE,0,1,c,c:GetCode())
end
function s.drfilter(c,cd)
	return c:IsFaceup() and c:IsCode(cd)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drcfilter,1,nil,tp,e:GetHandler():GetLinkedGroup())
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.cfilter(c,tp,zone,rp)
	local seq=c:GetPreviousSequence()
	if not c:IsPreviousControler(tp) then seq=seq+16 end
	return ((c:IsReason(REASON_BATTLE)) or (c:IsReason(REASON_EFFECT) and rp~=tp)) and c:IsType(TYPE_XYZ) 
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone()
	return eg:IsExists(s.cfilter,1,nil,tp,zone,rp)
end
function s.spfilter(c,e,tp,attr)
	return c:IsSetCard(0xdc) and c:GetOriginalAttribute() & attr ~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,tp,e:GetHandler():GetLinkedZone())
	local attr=0
	for tc in aux.Next(g) do
		attr=attr | tc:GetOriginalAttribute()
	end
	if chk==0 then
		return attr~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,attr)
	end
	e:SetLabel(attr)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
