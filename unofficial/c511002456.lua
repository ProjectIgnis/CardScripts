--分散プリズム
--Refracting Prism
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if chk==0 then
		local tc=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):GetFirst()
		local lvrklnk=(tc:HasLevel() and tc:GetLevel())
			or (tc:HasRank() and tc:GetRank())
			or (tc:IsLinkMonster() and tc:GetLink())
		return ct>1 and Duel.GetMZoneCount(tp,tc)>=ct and tc 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetOriginalCode(),tc:GetSetCard(),tc:GetType(),tc:GetAttack()/2,tc:GetDefense()/2,lvrklnk,tc:GetRace(),tc:GetAttribute(),tc:GetPosition())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=1 then return end
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if ct==0 then return end
	local tc=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):GetFirst()
	local lvrklnk=(tc:HasLevel() and tc:GetLevel())
		or (tc:HasRank() and tc:GetRank())
		or (tc:IsLinkMonster() and tc:GetLink())
	local code,set,typ,atk,def,race,attr,pos=tc:GetOriginalCode(),tc:GetSetCard(),tc:GetType(),tc:GetAttack()/ct,tc:GetDefense()/ct,tc:GetRace(),tc:GetAttribute(),tc:GetPosition()
	if Duel.GetMZoneCount(tp,tc)<ct
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,code,set,typ,atk,def,lvrklnk,race,attr) then return end
	local curr_code=tc:GetCode()
	local lvrklnk_eff_code=(tc:HasLevel() and EFFECT_CHANGE_LEVEL)
		or (tc:HasRank() and EFFECT_CHANGE_RANK)
		or (tc:IsLinkMonster() and EFFECT_CHANGE_LINK)
	local og=tc:GetOverlayGroup()
	if #og>0 then Duel.SendtoGrave(og,REASON_RULE) end
	Duel.RemoveCards(tc)
	for i=1,ct do
		local token=Duel.CreateToken(tp,code)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,pos) then
			--Set base stats
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(atk)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_BASE_DEFENSE)
			e2:SetValue(def)
			token:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(lvrklnk_eff_code)
			e3:SetValue(lvrklnk)
			token:RegisterEffect(e3)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CHANGE_RACE)
			e4:SetValue(race)
			token:RegisterEffect(e4)
			local e5=e1:Clone()
			e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e5:SetValue(attr)
			token:RegisterEffect(e5)
			local e6=e1:Clone()
			e6:SetCode(EFFECT_CHANGE_CODE)
			e6:SetValue(curr_code)
			token:RegisterEffect(e6)
		end
	end
	Duel.SpecialSummonComplete()
end