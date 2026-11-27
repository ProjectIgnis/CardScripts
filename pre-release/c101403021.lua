--災禍の根絶者
--Heretic Eradicator
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent would Special Summon exactly 1 monster, while this card is in your hand and your opponent has 4 or more monsters that cannot be Normal Summoned/Set in their face-up field, GY, and/or banishment (Quick Effect): You can negate the Summon, and if you do, destroy that monster, and if you do that, Special Summon this card (while you control no monsters, this effect and its activation cannot be negated)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.negspcon)
	e1:SetTarget(s.negsptg)
	e1:SetOperation(s.negspop)
	e1:SetLabel(id)
	c:RegisterEffect(e1)
	--While you control no monsters, this effect and its activation cannot be negated
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_CANNOT_INACTIVATE)
		ge1:SetValue(function(e,ct)
			local trig_eff=Chain.GetTriggeringEffect(ct)
			local trig_player=Chain.GetTriggeringPlayer(ct)
			return trig_eff:GetLabel()==id and Duel.GetFieldGroupCount(trig_player,LOCATION_MZONE,0)==0
		end)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_CANNOT_DISEFFECT)
		Duel.RegisterEffect(ge2,0)
	end)
	--You can send this card from the field to the GY; halve the ATK of 1 monster on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfToGrave)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.negspconfilter(c)
	return not c:IsSummonableCard() and c:IsMonster() and c:IsFaceup()
end
function s.negspcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetCurrentChain()==0 and #eg==1
		and Duel.IsExistingMatchingCard(s.negspconfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,4,nil)
end
function s.negsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.negspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.NegateSummon(eg)
	if Duel.Destroy(eg,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local sc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if sc then
		Duel.HintSelection(sc)
		--Halve the ATK of 1 monster on the field
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(sc:GetAttack()/2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
end