--Beltlink Wall Dragon
--ベルトリンク・ウォール・ドラゴン
--scripted by Larry126
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x48)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20838380,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--sp counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7200041,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetLabel(2)
	e2:SetTarget(s.addctg)
	e2:SetOperation(s.addcop)
	c:RegisterEffect(e2)
	--add counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7200041,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetLabel(1)
	e3:SetTarget(s.addctg)
	e3:SetOperation(s.addcop)
	c:RegisterEffect(e3)
	--cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsType,TYPE_LINK)))
	c:RegisterEffect(e4)
	--atk limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetValue(s.atlimit)
	c:RegisterEffect(e5)
	--remove counter
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(s.rmcon)
	e6:SetOperation(s.rmop)
	c:RegisterEffect(e6)
	--cannot summon
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(1,1)
	e7:SetTarget(s.sumlimit)
	c:RegisterEffect(e7)
end
function s.sumlimit(e,c)
	return c:IsLinkMonster() and c:GetLink()>e:GetHandler():GetCounter(0x48)
end
function s.dfilter(c,tp,ct)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsRace(RACE_DRAGON) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetLink()<ct
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.dfilter,1,nil,tp,e:GetHandler():GetCounter(0x48))
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x48)
	if ct>=2 then
		e:GetHandler():RemoveCounter(tp,0x48,2,REASON_EFFECT)
	end
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.addctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x48)
end
function s.addcop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x48,e:GetLabel())
	end
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_DRAGON) and c:IsLinkMonster()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
