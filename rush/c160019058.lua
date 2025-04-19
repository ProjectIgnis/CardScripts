--時の機械－タイム・マシーン
--Time Machine (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tc:GetPreviousControler(),LOCATION_MZONE)>0 and #eg==1
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,tc:GetPreviousPosition(),tc:GetPreviousControler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
function s.maxfilter(c,tc)
	return c:WasMaximumModeSide() and c:HasFlagEffect(FLAG_MAXIMUM_SIDE_RELATION+tc:GetCardID())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--0x2: second main monster zone/left main monster zone in Rush
	--0x4: middle main monster zone
	--0x8: fourth main monster zone/right main monster zone in Rush
	local tc=eg:GetFirst()
	if tc:WasMaximumMode() then
		Duel.SpecialSummon(tc,0,tp,tc:GetPreviousControler(),false,false,tc:GetPreviousPosition(),0x4)
		tc:RegisterFlagEffect(FLAG_MAXIMUM_CENTER,RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD,0,1)
		local maxg=Duel.GetMatchingGroup(s.maxfilter,tc:GetPreviousControler(),LOCATION_GRAVE,0,nil,tc)
		for maxc in maxg:Iter() do
			local zone=0x8
			if maxc.MaximumSide=="Left" then zone=0x2 end
			maxc:RegisterFlagEffect(FLAG_MAXIMUM_SIDE,RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD,0,1)
			Duel.MoveToField(maxc,tc:GetPreviousControler(),tc:GetPreviousControler(),LOCATION_MZONE,POS_FACEUP_ATTACK,true,zone)
		end
	else
		Duel.SpecialSummon(tc,0,tp,tc:GetPreviousControler(),false,false,tc:GetPreviousPosition())
	end
end