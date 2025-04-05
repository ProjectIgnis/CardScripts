--一か八か
--One or Eight
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if tc:IsMonster() and (tc:IsLevel(1) or tc:IsLevel(8)) then
		aux.ToHandOrElse(tc,tp,
							function(c) return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end,
							function(c) Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
							aux.Stringid(id,1)
						)
	else
		if not Duel.SelectEffectYesNo(1-tp,e:GetHandler()) then return end
		local op=Duel.SelectOption(1-tp,aux.Stringid(id,2),aux.Stringid(id,3))
		local p=e:GetHandler():GetControler()
		if op==0 then
			Duel.SetLP(p,1000)
		elseif op==1 then
			local recv=8000-Duel.GetLP(1-p)
			if recv<0 then recv=0 end
			Duel.Recover(1-p,recv,REASON_EFFECT)
		end
	end
end