--Galactic Fury
--  By Shad3

local scard=s

function scard.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(scard.cd)
	e1:SetTarget(scard.tg)
	e1:SetOperation(scard.op)
	c:RegisterEffect(e1)
	--Global check
	if not scard.gl_chk then
		scard.gl_chk=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(scard.reg_op)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_TURN_END)
		ge2:SetOperation(scard.clr_op)
		Duel.RegisterEffect(ge2,0)
		scard.dmg={[0]=0,[1]=0}
	end
end

function scard.reg_op(e,tp,eg,ep,ev,re,r,rp)
	scard.dmg[ep]=scard.dmg[ep]+ev
end

function scard.clr_op(e,tp,eg,ep,ev,re,r,rp)
	scard.dmg[0]=0
	scard.dmg[1]=0
end

function scard.cd(e,tp,eg,ep,ev,re,r,rp)
	return scard.dmg[tp]>0
end

function scard.sum_fil(c,e,tp)
	return c:IsSetCard(0x7b) and c:IsDefenseBelow(scard.dmg[tp]) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function scard.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(scard.sum_fil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,scard.sum_fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(o,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end

function scard.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end