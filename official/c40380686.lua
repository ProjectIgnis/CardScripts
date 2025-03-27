--ドロゴン・ベビー
--Baby Mudragon
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Can be treated as non-Tuner for a Synchro Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	--Change Type or Attribute of a Synchro Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
function s.chfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsCanBeEffectTarget(e)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>0 end
	if Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==0 then
		local rc=Duel.AnnounceAnotherRace(g,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local sg=g:FilterSelect(tp,Card.IsDifferentRace,1,1,nil,rc)
		Duel.SetTargetCard(sg)
		e:SetLabel(0,rc)
	else
		local att=Duel.AnnounceAnotherAttribute(g,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local sg=g:FilterSelect(tp,Card.IsAttributeExcept,1,1,nil,att)
		Duel.SetTargetCard(sg)
		e:SetLabel(1,att)
	end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local op,decl=e:GetLabel()
	if op==0 and tc:IsDifferentRace(decl) then
		--Change monster type
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(decl)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	elseif op==1 and tc:IsAttributeExcept(decl) then
		--Change attribute
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(decl)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end