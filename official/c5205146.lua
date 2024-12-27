--無限起動ロードローラー
--Infinitrack Road Roller
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself if an EARTH Machine monster is Tributed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_RELEASE)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetLabel(0)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Special Summon itself if an EARTH Machine monster is banished face-up
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	--If attached to a Machine Xyz monster, monsters your opponent controls are changed to Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.poscond)
	e3:SetTarget(function(_,c) return c:IsFaceup() end)
	e3:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e3)
	--If attached to a Machine Xyz monster, monsters your opponent controls lose 1000 DEF
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(s.poscond)
	e4:SetValue(-1000)
	c:RegisterEffect(e4)
end
function s.cfilter(c,label)
	if label==1 and c:IsFacedown() then return false end
	if c:IsPreviousLocation(LOCATION_MZONE) then
		return c:GetPreviousAttributeOnField()&ATTRIBUTE_EARTH>0 and c:GetPreviousRaceOnField()&RACE_MACHINE>0
	else
		return c:IsMonster() and c:IsOriginalAttribute(ATTRIBUTE_EARTH) and c:IsOriginalRace(RACE_MACHINE)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e:GetLabel())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
function s.poscond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsOriginalRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end