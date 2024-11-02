--ＶＶ－百識公国
--Vaylantz World - Konig Wissen
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Place in the Spell/Trap Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.plcon)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VAYLANTZ}
s.listed_names={id}
function s.filter(c)
	return c:IsFieldSpell() and c:IsSetCard(SET_VAYLANTZ) and not c:IsCode(id) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)==2
end
function s.plfilter(c,tp)
	if not (c:IsFaceup() and c:IsType(TYPE_EFFECT)) then return false end
	local cg=c:GetColumnGroup()
	return #cg>0 and cg:IsExists(aux.AND(Card.IsControler,Card.IsMonster),1,nil,tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MMZONE) and s.plfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,tp,0,LOCATION_MMZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.plfilter,tp,0,LOCATION_MMZONE,1,1,nil,tp):GetFirst()
	local dc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,tc:GetSequence())
	if dc then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dc,1,0,0)
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e)) then return end
	local seq=tc:GetSequence()
	local dc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,seq)
	if dc then
		Duel.Destroy(dc,REASON_RULE)
	end
	if Duel.CheckLocation(1-tp,LOCATION_SZONE,seq)
		and Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard(),1<<seq) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end