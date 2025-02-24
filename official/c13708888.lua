--Ｅ－ＨＥＲＯ ネオス・ロード
--Evil HERO Neos Lord
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Elemental HERO Neos" or 1 Fusion Monster that mentions it + 1 Effect Monster on the field
	Fusion.AddProcMix(c,true,true,{CARD_NEOS,s.neosfusionmatfilter},s.effectmatfilter)
	c:AddMustBeSpecialSummonedByDarkFusion()
	--Take control of 1 face-up monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ctrltg)
	e1:SetOperation(s.ctrlop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ctrlcon)
	c:RegisterEffect(e2)
	--Cannot be destroyed by battle or card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_NEOS,CARD_DARK_FUSION}
s.listed_series={SET_HERO,SET_EVIL_HERO}
s.material_setcode={SET_ELEMENTAL_HERO,SET_HERO,SET_NEOS}
function s.neosfusionmatfilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:ListsCode(CARD_NEOS)
end
function s.effectmatfilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,fc,sumtype,tp) and c:IsOnField()
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
function s.ctrlconfilter(c,tp)
	return c:IsControler(1-tp) and c:IsMonster()
end
function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctrlconfilter,1,nil,tp)
end