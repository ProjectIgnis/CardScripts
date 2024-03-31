--野性なるバリア －ノラーフォース－
--Stray Force
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,-200)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_MZONE)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsNotMaximumModeSide()
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST|RACE_BEASTWARRIOR|RACE_WARRIOR) and c:IsDefense(200) and not c:IsMaximumModeSide()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if a and a:IsAttackPos() and a:IsRelateToBattle() then
		--atk decrease
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-200)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		a:RegisterEffect(e1)
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		local sg=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_MZONE,0,nil)
		if #sg==3 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end