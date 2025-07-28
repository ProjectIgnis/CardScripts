--デメット爺さん
--Grandpa Demetto
--Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--Special Summon up to 2 Normal Monsters with 0 ATK or DEF from your GY, each as a Level 8 DARK monster in Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Destroy 1 monster your opponent controls and inflict damageto your opponent equal to the Xyz Monster's Rank x 300
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Global check
	aux.GlobalCheck(s,function()
		s[0]=nil
		s[1]=Group.CreateGroup()
		local tmp_g=Group.CreateGroup()
		--Keep track of an Xyz Monster activating its effect by detaching a Normal Monster
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DETACH_MATERIAL)
		ge1:SetLabelObject(tmp_g)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
					local cid=Duel.GetCurrentChain()
					if cid>0 and #tmp_g>0 then 
						s[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID)
						s[1]=tmp_g-eg:GetFirst():GetOverlayGroup()
						tmp_g:Clear()
					end
				end)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
		ge2:SetLabelObject(ge1)
		ge2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
					tmp_g:Merge(re:GetHandler():GetOverlayGroup())
					return false
				end)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_names={CARD_PRINCESS_COLOGNE}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local xyzg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,CARD_PRINCESS_COLOGNE),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #xyzg>0 and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST,xyzg) end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST,xyzg)
end
function s.spfilter(c,e,tp)
	c:AssumeProperty(ASSUME_LEVEL,8)
	c:AssumeProperty(ASSUME_ATTRIBUTE,ATTRIBUTE_DARK)
	return c:IsType(TYPE_NORMAL) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	ct=math.min(ct,2)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	if #g==0 then return end
	local c=e:GetHandler()
	for sc in g:Iter() do
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			--Special Summon each one as a Level 8 DARK monster
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_DARK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(8)
			sc:RegisterEffect(e2)
		end
	end
	Duel.SpecialSummonComplete()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==s[0] and re:GetHandler():IsControler(tp) and re:IsActiveType(TYPE_XYZ)
		and s[1] and s[1]:IsExists(Card.IsOriginalType,1,nil,TYPE_NORMAL)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return false end
	local rc=re:GetHandler()
	if chk==0 then return rc:IsCanBeEffectTarget(e) and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,rc) end
	Duel.SetTargetCard(rc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,rc):GetFirst()
	e:SetLabelObject({tc,rc})
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,rc:GetRank()*300)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local opp_c,xyz_c=table.unpack(e:GetLabelObject())
	if opp_c:IsRelateToEffect(e) and opp_c:IsControler(1-tp) and Duel.Destroy(opp_c,REASON_EFFECT)>0
		and xyz_c:IsRelateToEffect(e) and xyz_c:IsFaceup() then
		Duel.Damage(1-tp,xyz_c:GetRank()*300,REASON_EFFECT)
	end
end
