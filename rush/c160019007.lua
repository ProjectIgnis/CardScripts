--ダイスキー・ミクス
--Dice Key Mix
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--dice
	local params={nil,s.matfilter,nil,nil,nil,s.stage2}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON|CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.matfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_FAIRY) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.filter(c)
	return c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local d=Duel.TossDice(tp,1)
		e:SetLabel(d)
		if d==1 then
			local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,LOCATION_ONFIELD,0,nil)
			if #dg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=dg:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		else
			if fustg(e,tp,eg,ep,ev,re,r,rp,0) then
				fusop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
function s.stage2(e,tc,tp,mg,chk)
	local label=e:GetLabel()
	if chk==0 and (label==5 or label==6) then
		--Protection
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetDescription(3060)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(aux.indoval)
		tc:RegisterEffect(e1)
	end
end