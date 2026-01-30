--Ｈ・Ｅ・Ｒ・Ｏ フラッシュ！
--H-E-R-O Flash!
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ELEMENTAL_HERO}
function s.thspfilter(c,e,tp,mmz_chk)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsMonster() and (c:IsAbleToHand()
		or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local max_count=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_ELEMENTAL_HERO),tp,LOCATION_MZONE,0,nil)
	local b1=not Duel.HasFlagEffect(tp,id)
	local b2=max_count>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
	local b3=Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,mmz_chk)
	local b4=not Duel.HasFlagEffect(tp,id+100)
	if chk==0 then return b1 or b2 or b3 or b4 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)},
		{b4,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		e:SetProperty(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,max_count,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	elseif op==4 then
		e:SetCategory(0)
		e:SetProperty(0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	if op==1 then
		--● If your "Elemental HERO" monster attacks a Defense Position monster this turn, inflict piercing battle damage to your opponent
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,5))
		--Your "Elemental HERO" monsters inflict piercing battle damage
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return c:IsSetCard(SET_ELEMENTAL_HERO) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		--● Target cards your opponent controls up to the number of "Elemental HERO" monsters you control; destroy them
		local tg=Duel.GetTargetCards(e)
		if #tg>0 then
			Duel.Destroy(tg,REASON_EFFECT)
		end
	elseif op==3 then
		--● Add to your hand, or Special Summon, 1 "Elemental HERO" monster from your GY
		local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,6))
		local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mmz_chk):GetFirst()
		if not sc then return end
		aux.ToHandOrElse(sc,tp,
			function() return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
			function() Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
			aux.Stringid(id,7)
		)
	elseif op==4 then
		--● "Elemental HERO" monsters can attack directly this turn
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,8))
		--"Elemental HERO" monsters can attack directly this turn
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e2:SetTarget(function(e,c) return c:IsSetCard(SET_ELEMENTAL_HERO) end)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end