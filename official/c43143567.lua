--黄金郷のアンヘルカイド
--Angelcaido of the Golden Land
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Eldlich the Golden Lord" + 1 Zombie monster
	Fusion.AddProcMix(c,true,true,CARD_GOLDEN_LORD,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE))
	c:AddMustBeFusionSummoned()
	--You can only Fusion Summon or Special Summon by its alternate procedure "Angelcaido of the Golden Land" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--You can Special Summon this card by Tributing 1 LIGHT Zombie monster while you have "Eldlich the Golden Lord" in your field or GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Special Summon 1 "Eldlich" monster from your Deck, Extra Deck, or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_GOLDEN_LORD,id}
s.material_setcode={SET_ELDLICH}
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Prevent another Fusion Summon or Special Summon by its alternate procedure of "Angelcaido of the Golden Land" that turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.selfspcostfilter(c,tp,sc)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_ZOMBIE) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.selfspcon(e,c)
	if not c then return true end
	if c:IsFaceup() then return false end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_GOLDEN_LORD),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		and Duel.CheckReleaseGroup(tp,s.selfspcostfilter,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.selfspcostfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if not g then return false end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end
function s.spfilter(c,e,tp,ft)
	if not (c:IsSetCard(SET_ELDLICH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		return ft>0
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,ft) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end