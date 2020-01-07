--Galactic Fury
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.cd)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Global check
	if not s.gl_chk then
		s.gl_chk=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.reg_op)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_TURN_END)
		ge2:SetOperation(s.clr_op)
		Duel.RegisterEffect(ge2,0)
		s.dmg={[0]=0,[1]=0}
	end
end
function s.reg_op(e,tp,eg,ep,ev,re,r,rp)
	s.dmg[ep]=s.dmg[ep]+ev
end
function s.clr_op(e,tp,eg,ep,ev,re,r,rp)
	s.dmg[0]=0
	s.dmg[1]=0
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
	return s.dmg[tp]>0
end
function s.sum_fil(c,e,tp)
	return c:IsSetCard(0x7b) and c:IsDefenseBelow(s.dmg[tp]) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.sum_fil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.sum_fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(o,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end