--連鎖破壊
--Chain Destruction
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Hidden Token to check eligible names when Tokens/Extra Deck Monsters are Summoned
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
		ge1:SetOperation(s.createtoken)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.filter(c,e,codechk)
	return c:IsFaceup() and c:IsAttackBelow(2000) and (not e or c:IsCanBeEffectTarget(e)) and (not codechk or s.mdnamecheck(c))
end
function s.mdnamecheck(c)
	if c:IsType(TYPE_TOKEN|TYPE_EXTRA) or c:IsHasEffect(EFFECT_CHANGE_CODE) then
		local codes={c:GetCode()}
		for _,code in ipairs(codes) do
			s.CheckCodeToken:Recreate(code)
			if not s.CheckCodeToken:IsType(TYPE_TOKEN|TYPE_EXTRA) then
				return true
			end
		end
		return false
	end
	return true
end
function s.publicfilter(c,p,...)
	return c:IsCode(...) and (c:IsPublic() or (c:IsLocation(LOCATION_DECK) and c:GetSequence()==Duel.GetFieldGroupCount(p,LOCATION_DECK,0)-1 and Duel.IsPlayerAffectedByEffect(p,EFFECT_REVERSE_DECK)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,nil,true) end
	if chk==0 then return eg:IsExists(s.filter,1,nil,e,true) end
	local tc
	if #eg==1 then
		Duel.SetTargetCard(eg)
		tc=eg:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=eg:FilterSelect(tp,s.filter,1,1,nil,e,true)
		Duel.SetTargetCard(g)
		tc=g:GetFirst()
	end
	local p=tc:GetControler()
	local public=Duel.GetMatchingGroup(s.publicfilter,p,LOCATION_DECK|LOCATION_HAND,0,nil,p,tc:GetCode())
	if #public>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,public,#public,p,LOCATION_DECK|LOCATION_HAND)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,p,LOCATION_DECK|LOCATION_HAND)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local dg=Duel.GetMatchingGroup(Card.IsCode,tc:GetControler(),LOCATION_DECK|LOCATION_HAND,0,nil,tc:GetCode())
	Duel.Destroy(dg,REASON_EFFECT)
end

function s.createtoken(e)
	s.CheckCodeToken=Duel.CreateToken(0,0)
	e:Reset()
end