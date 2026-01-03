--紫毒の茨牙
--Thorn Fangs of Violet Poison
--Scripted by The Razgriz
local s,id=GetID()
local CARD_STARVING_VENOM_FUSION_DRAGON=41209827
function s.initial_effect(c)
	--Make 1 "Starving Venom Fusion Dragon" you control unable to attack for the rest of this turn, also destroy as many monsters your opponent controls as possible with less ATK than that monster, then you can discard your entire hand, and if you do, inflict damage to your opponent equal to the combined original ATK of those destroyed monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PREDAP}
s.listed_names={CARD_STARVING_VENOM_FUSION_DRAGON}
function s.tgfilter(c,tp)
	return c:IsCode(CARD_STARVING_VENOM_FUSION_DRAGON) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackBelow,c:GetAttack()-1),tp,0,LOCATION_MZONE,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackBelow,tc:GetAttack()-1),tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetSum(Card.GetBaseAttack))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--It cannot attack for the rest of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackBelow,tc:GetAttack()-1),tp,0,LOCATION_MZONE,nil)
		local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 and #hg>0 and #hg==hg:FilterCount(Card.IsDiscardable,nil,REASON_EFFECT)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local dam=Duel.GetOperatedGroup():Match(aux.NOT(Card.IsTextAttack),nil,-2):GetSum(Card.GetTextAttack)
			Duel.BreakEffect()
			if Duel.SendtoGrave(hg,REASON_EFFECT|REASON_DISCARD)==#hg then
				Duel.Damage(1-tp,dam,REASON_EFFECT)
			end
		end
	end
end