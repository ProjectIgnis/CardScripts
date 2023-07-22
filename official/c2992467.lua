--クリック＆エコー
--Click & Echo
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be used as material for a Fusion, Synchro, or Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ))
	c:RegisterEffect(e1)
	--Cannot be Tributed while face-up in the Monster Zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
	--Special Summon it to the field of the opponent of the player that used this card as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(2,id)
	e2:SetCondition(s.spcond)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--You must play with your hand revealed if this card was summoned by its own effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e3:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e3)
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SpecialSummonStep(c,0,tp,1-rp,false,false,POS_FACEUP_DEFENSE) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
	end
	Duel.SpecialSummonComplete()
end