--機巧伝－神使記紀図
--Sacred Scrolls of the Gizmek Legend
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x206)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Excavate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.exctg)
	e2:SetOperation(s.excop)
	c:RegisterEffect(e2)
	--Place counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.countcon)
	e3:SetOperation(s.countop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--Cannot activate
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,1)
	e5:SetCondition(s.limitcon)
	e5:SetValue(s.aclimit)
	c:RegisterEffect(e5)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.excfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsDefense(c:GetAttack()) and c:IsAbleToHand()
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local hg=g:Filter(s.excfilter,nil)
	Duel.DisableShuffleCheck()
	if #g>0 then 
		if #hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=hg:Select(tp,1,1,nil)
			if sg:GetFirst():IsAbleToHand() then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
				Duel.ShuffleHand(tp)
				g:RemoveCard(sg:GetFirst())
			else
				Duel.SendtoGrave(sg,REASON_RULE)
			end
		end
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsDefense(c:GetAttack())
end
function s.countcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.countop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x206,1)
end
function s.limitcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x206)>=10
end
function s.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	local rc=re:GetHandler()
	return loc==LOCATION_MZONE and re:IsMonsterEffect() and rc:IsDefenseAbove(0) and not rc:IsDefense(rc:GetAttack())
end