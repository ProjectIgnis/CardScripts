--Ｒｅｃｅｔｔｅ ｄｅ Ｐｅｒｓｏｎｎｅｌ～賄いのレシピ～
--Recette de Personnel - Cook's Recipe
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Special Summon 1 "Nouvellez Token"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tokentg)
	e1:SetOperation(s.tokenop)
	c:RegisterEffect(e1)
	local rparams={filter=aux.FilterBoolFunction(Card.IsSetCard,SET_NOUVELLEZ),lvtype=RITPROC_EQUAL,forcedselection=s.forced}
	--Ritual Summon 1 "Nouvellez" Ritual Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.rtcost)
	e2:SetTarget(Ritual.Target(rparams))
	e2:SetOperation(Ritual.Operation(rparams))
	c:RegisterEffect(e2)
end
s.listed_names={id+100}
s.listed_series={SET_NOUVELLEZ}
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsRitualMonster() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,SET_NOUVELLEZ,TYPES_TOKEN,50,50,1,RACE_FIEND,ATTRIBUTE_DARK)
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsRitualMonster),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsRitualMonster),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,SET_NOUVELLEZ,TYPES_TOKEN,50,50,1,RACE_FIEND,ATTRIBUTE_DARK) then return false end
	local tc=Duel.GetFirstTarget()
	local token=Duel.CreateToken(tp,id+100)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Change its Level
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function s.rtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.forced(e,tp,g,sc)
	local c=e:GetHandler()
	return not g:IsContains(c),g:IsContains(c)
end