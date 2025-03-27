--世壊賛歌
--Realm Eulogy
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster you control and negate the effects of 1 of your opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.negttg)
	e1:SetOperation(s.negtop)
	c:RegisterEffect(e1)
	--Destroy 1 card you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descond)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VEDA}
s.listed_names={CARD_VISAS_STARFROST}
function s.cfilter(c,e,tp)
	return (c:IsControler(tp) or (c:IsControler(1-tp) and c:IsNegatableMonster() and c:IsType(TYPE_EFFECT)))
		and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.negttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	local dg,ng=tg:Split(Card.IsControler,nil,tp)
	e:SetLabelObject(dg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,ng,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,ng,1,0,0)
end
function s.negtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local dc=g:GetFirst()
	local negc=g:GetNext()
	if negc==e:GetLabelObject() then dc,negc=negc,dc end
	if dc and dc:IsControler(tp) and Duel.Destroy(dc,REASON_EFFECT)>0
		and negc and negc:IsControler(1-tp) and negc:IsFaceup() and negc:IsCanBeDisabledByEffect(e) then
		negc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_VISAS_STARFROST),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.AdjustInstantly()
			Duel.BreakEffect()
			Duel.Destroy(negc,REASON_EFFECT)
		end
	end
end
function s.vedafilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VEDA) and c:IsOriginalType(TYPE_MONSTER)
end
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.vedafilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
	end
end