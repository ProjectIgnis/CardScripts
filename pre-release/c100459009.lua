--波動の超魔導剣士－ブラック・パラディン
--Dark Paladin - Wave-Motion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Dark Magician" + 1 Level 7 or higher monster
	Fusion.AddProcMix(c,true,true,CARD_DARK_MAGICIAN,aux.FilterBoolFunctionEx(Card.IsLevelAbove,7))
	c:AddMustBeFusionSummoned()
	--Gains 500 ATK for every other monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c)
		return 500*Duel.GetMatchingGroupCount(nil,0,LOCATION_MZONE,LOCATION_MZONE,c)
	end)
	c:RegisterEffect(e1)
	--Can attack all your opponent's monsters, once each
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Once per turn, when your opponent activates a Spell Card or effect (Quick Effect): You can negate that effect, then you can destroy 1 card on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return rp==1-tp and re:IsSpellEffect() and Duel.IsChainDisablable(ev)
	end)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if Duel.NegateEffect(ev) then
			local g=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local dg=g:Select(tp,1,1,nil)
				Duel.HintSelection(dg)
				Duel.BreakEffect()
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end)
	c:RegisterEffect(e3)
	--After this card destroys a card by battle or card effect and sends it to the GY, neither player can activate its effects while it is in the GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_ALL)
	e4:SetOperation(s.cannotactop)
	c:RegisterEffect(e4)
end
s.material_setcode={SET_DARK_MAGICIAN}
s.listed_names={CARD_DARK_MAGICIAN}
function s.cannotactfilter(c,rc,re_chk)
	return (rc:IsReasonCard(c) or re_chk) and c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsLocation(LOCATION_GRAVE)
end
function s.cannotactop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local re_chk=re and re:GetHandler()==c
	local g=eg:Filter(s.cannotactfilter,nil,c,re_chk)
	for tc in g:Iter() do
		--Neither player can activate its effects while it is in the GY
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE)
		tc:RegisterEffect(e1)
	end
end