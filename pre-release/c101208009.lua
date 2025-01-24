--紋章獣グリフォン
--Heraldic Beast Gryphon
--scripted by Naim
local EFFECT_DOUBLE_XYZ_MATERIAL=511001225 --to be removed when the procedure is updated
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Can be treated as 2 Materials for the Xyz Summon of a "Number" Xyz monter that requires 3 or more materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e2:SetValue(1)
	e2:SetCondition(function(e) return not Duel.HasFlagEffect(e:GetHandlerPlayer(),id) end)
	e2:SetOperation(function(e,c,matg) return c:IsSetCard(SET_NUMBER) and c.minxyzct and c.minxyzct>=3 and matg:FilterCount(s.gryphonhoptfilter,nil)<2 end)
	c:RegisterEffect(e2)
	--HOPT workaround for having already used the double material effect earlier in that turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(s.valcheck)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_HERALDIC_BEAST}
s.listed_names={id}
function s.costfilter(c)
	return c:IsSetCard(SET_HERALDIC_BEAST) and c:IsMonster() and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--Cannot Special Summon from the Extra Deck for the rest of this turn, except by Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsLocation(LOCATION_EXTRA) and (sumtype&SUMMON_TYPE_XYZ)~=SUMMON_TYPE_XYZ end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Can only use monsters with "Heraldic Beast" and/or "Number" in their original names as material for an Xyz Summon this turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e2:SetTarget(function(e,c) return not c:IsOriginalSetCard({SET_HERALDIC_BEAST,SET_NUMBER}) end)
	e2:SetValue(function(e,c) return c and c:IsControler(e:GetHandlerPlayer()) end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.gryphonhoptfilter(c)
	return c:IsCode(id) and c:IsHasEffect(EFFECT_DOUBLE_XYZ_MATERIAL)
end
function s.valcheck(e,c)
	if not (c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER) and c.minxyzct and c.minxyzct>=3) then return end
	local g=c:GetMaterial()
	if #g<c.minxyzct and g:IsExists(s.gryphonhoptfilter,1,nil) then
		Duel.RegisterFlagEffect(c:GetControler(),id,RESET_PHASE|PHASE_END,0,1)
	end
end