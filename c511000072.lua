--T.G. Cyber Magician (TF5)
local s,id=GetID()
function s.initial_effect(c)
	--synchro limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.synlimit)
	c:RegisterEffect(e1)
	--synchro custom
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetTarget(s.syntg)
	e2:SetValue(1)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
	--Type Machine
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_RACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(RACE_MACHINE)
	c:RegisterEffect(e3)
	--Add to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.scon)
	e4:SetTarget(s.stg)
	e4:SetOperation(s.sop)
	c:RegisterEffect(e4)
end
s.listed_names={64910482}
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x27)
end
s.tuner_filter=aux.FALSE
function s.synfilter(c,syncard,tuner,f,lv)
	return c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c)) and c:GetLevel()==lv
end
function s.syntg(e,syncard,f,minc)
	local c=e:GetHandler()
	if minc>1 then return false end
	local lv=syncard:GetLevel()-c:GetLevel()
	if lv<=0 then return false end
	return Duel.IsExistingMatchingCard(s.synfilter,syncard:GetControler(),LOCATION_HAND,0,1,nil,syncard,c,f,lv)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,minc)
	local c=e:GetHandler()
	local lv=syncard:GetLevel()-c:GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_HAND,0,1,1,nil,syncard,c,f,lv)
	Duel.SetSynchroMaterial(g)
end
function s.scon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
function s.sfilter(c)
	return c:IsCode(64910482) and c:IsAbleToHand()
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
