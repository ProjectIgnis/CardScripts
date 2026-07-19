--ＤＤＤ双暁王カリ・ユガ
--D/D/D Duo-Dawn King Kali Yuga (Anime)
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 8 "D/D" monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_DD),8,2)
	--This card's effects cannot be negated
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_CANNOT_DISABLE)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetCode(EFFECT_CANNOT_DISEFFECT)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetValue(function(e,ct) return Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT):GetHandler()==e:GetHandler() end)
	c:RegisterEffect(e1b)
	--If this card is Special Summoned: Negate the effects of all other face-up cards currently on the field, until the end of this turn. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55888045,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--(Quick Effect): You can detach 1 Xyz Material from this card; destroy all Spells/Traps on the field.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15939229,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--If a card(s) were destroyed by the above effect: You can detach 1 Xyz Material from this card; return all cards that were destroyed on your side of the field to the same zone and postion they were in when they were destroyed.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabelObject(e3)
	e4:SetCondition(s.retcon)
	e4:SetCost(Cost.DetachFromSelf(1))
	e4:SetTarget(s.rettg)
	e4:SetOperation(s.retop)
	c:RegisterEffect(e4)
	--Register a "Double Snare" check on Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_DD}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(3682106)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	for tc in g:Iter() do
		tc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #sg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
function s.retcardfilter(c,tp,e)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonEffect()==e
end
function s.retlocfilter(c,tp)
	return Duel.CheckLocation(tp,c:GetPreviousLocation(),c:GetPreviousSequence())
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.retcardfilter,1,nil,tp,e:GetLabelObject())
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.retcardfilter,nil,tp,e:GetLabelObject())
	if chk==0 then return not g:IsExists(aux.NOT(s.retlocfilter),1,nil,tp) end
	Duel.SetTargetCard(g)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<=0 or g:IsExists(aux.NOT(s.retlocfilter),1,nil,tp) then return end
	for tc in g:Iter() do
		if tc:IsPreviousLocation(LOCATION_PZONE) then
			local seq=0
			if tc:GetPreviousSequence()==7 or tc:GetPreviousSequence()==4 then seq=1 end
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,tc:GetPreviousPosition(),true,(1<<seq))
		else
			Duel.MoveToField(tc,tp,tp,tc:GetPreviousLocation(),tc:GetPreviousPosition(),true,(1<<tc:GetPreviousSequence()))
		end
	end
end
